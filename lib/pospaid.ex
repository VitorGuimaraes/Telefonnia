defmodule Pospaid do
  defstruct value: 0
  @minute_cost 1.4

  def make_call(number, date, duration) do
    Subscriber.query_subscriber(number, :pospaid)
    |> Call.register_call(date, duration)

    {:ok, "Call made successfully"}
  end

  def print_bill(month, year, number) do
    subscriber = Account.print(month, year, number, :pospaid)

    total_value = subscriber.calls
    |> Enum.map(&(&1.duration * @minute_cost))
    |> Enum.sum()

    %Subscriber{subscriber | plan: %__MODULE__{value: total_value}}

  end
end
