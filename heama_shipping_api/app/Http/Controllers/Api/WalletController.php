<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\WalletTransactionResource;
use App\Models\FxRate;
use App\Services\InsufficientBalanceException;
use App\Services\PricingService;
use App\Services\WalletService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use RuntimeException;

class WalletController extends Controller
{
    public function __construct(private readonly WalletService $wallet) {}

    /** GET /wallet — balance + recent transactions. */
    public function show(Request $request): JsonResponse
    {
        $user = $request->user();

        // The ledger is the source of truth — recompute the balances from it and
        // fix the wallet if it drifted. Runs on every wallet load (login/home and
        // when the ledger page opens), so the shown balance is always correct.
        $balances = $this->wallet->reconcile($user);

        $transactions = $user->walletTransactions()
            ->latest()
            ->limit(50)
            ->get();

        // Cash-on-delivery now debits the wallet like any other payment (the
        // balance may go negative — that's what the customer settles in cash on
        // arrival), so there's no separate "to pay on delivery" figure.

        return response()->json([
            'balance_iqd' => $balances['IQD'],
            'balance_usd' => $balances['USD'],
            // The pricing inputs (rates, markup, rounding) the Me page's rate
            // cards and calculator use to show exactly what the cart charges.
            // A rate of 0 means it isn't configured in fx_rates yet.
            ...app(PricingService::class)->publicRates(),
            'transactions' => WalletTransactionResource::collection($transactions)->resolve(),
        ]);
    }

    /** POST /wallet/exchange — move money between the IQD and USD balances. */
    public function exchange(Request $request): JsonResponse
    {
        $data = $request->validate([
            'from' => ['required', Rule::in(['IQD', 'USD'])],
            'to' => ['required', Rule::in(['IQD', 'USD'])],
            'amount' => ['required', 'numeric', 'min:0.01'],
        ]);

        try {
            $balances = $this->wallet->exchange(
                $request->user(),
                $data['from'],
                $data['to'],
                (float) $data['amount'],
            );
        } catch (InsufficientBalanceException $e) {
            return response()->json(['message' => 'Not enough balance to exchange that amount.'], 422);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'balance_iqd' => $balances['IQD'],
            'balance_usd' => $balances['USD'],
            'usd_rate' => (float) FxRate::rateFor('USD'),
        ]);
    }
}
