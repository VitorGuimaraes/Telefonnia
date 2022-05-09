defmodule Recharge do
  defstruct [:date, :value]

  def new(date, value, number) do
    subscriber = Subscriber.query_subscriber(number, :prepaid)
    plan = subscriber.plan

    plan = %Prepaid{plan
          | credits: plan.credits + value,
            recharges: plan.recharges ++ [%__MODULE__{date: date, value: value}]}
    subscriber = %Subscriber{subscriber | plan: plan}
    Subscriber.update_subscriber(subscriber)
    {:ok, "Recharge done!"}
  end
end
