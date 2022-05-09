defmodule Account do

  def print(month, year, number, plan) do
    subscriber = Subscriber.query_subscriber(number)
    month_calls = query_month_calls(subscriber.calls, month, year)

    cond do
      plan == :prepaid ->
        month_recharges = query_month_calls(subscriber.plan.recharges, month, year)
        plan = %Prepaid{subscriber.plan | recharges: month_recharges}
        %Subscriber{subscriber | calls: month_calls, plan: plan}

        plan == :pospaid ->
        %Subscriber{subscriber | calls: month_calls}

    end
  end

  def query_month_calls(calls, month, year) do
    calls
    |> Enum.filter(fn call ->
      call.date.year == year && call.date.month == month
    end)
  end
end
