defmodule Prepaid do
  defstruct credits: 0, recharges: []
  @minute_price 1.45

  def make_call(number, date, duration) do
   subscriber = Subscriber.query_subscriber(number, :prepaid)
   cost = duration * @minute_price

    cond do
      cost <= subscriber.plan.credits ->
      plan = subscriber.plan
      plan = %__MODULE__{plan | credits: plan.credits - cost}

      subscriber = %Subscriber{subscriber | plan: plan}
      Call.register_call(subscriber, date, duration)
      {:ok, "This call costs $#{cost} and you have $#{plan.credits} credits"}

      true -> {:error, "Insufficient credits, make a recharge!"}
    end
  end

  def print_bill(month, year, number) do
    Account.print(month, year, number, :prepaid)
  end
end
