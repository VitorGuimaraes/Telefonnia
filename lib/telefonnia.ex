defmodule Telefonnia do

  def start do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))
  end

  def register(name, number, plan) do
    Subscriber.register(name, number, plan)
  end

  def list_subscribers, do: Subscriber.subscribers()
  def list_subscribers_prepaid, do: Subscriber.prepaid_subscribers()
  def list_subscribers_pospaid, do: Subscriber.pospaid_subscribers()

  def make_call(number, plan, date, duration) do
    cond do
      plan == :prepaid ->
        Prepaid.make_call(number, date, duration)

      plan == :pospaid ->
        Pospaid.make_call(number, date, duration)
    end
  end

  def recharge(number, date, value), do: Recharge.new(date, value, number)

  def query_by_number(number, plan \\ :all), do: Subscriber.query_subscriber(number, plan)

  def print_bills(month, year) do
    Subscriber.prepaid_subscribers()
    |> Enum.each(fn subscriber ->
      subscriber = Prepaid.print_bill(month, year, subscriber.number)
      IO.puts "Prepaid account from subscriber: #{subscriber.name}"
      IO.puts "Number: #{subscriber.number}"
      IO.puts "Calls: "
      IO.inspect(subscriber.calls)
      IO.puts "Recharges: "
      IO.inspect(subscriber.plan.recharges)
      IO.puts "Total calls: #{Enum.count(subscriber.calls)}"
      IO.puts "Total recharges: #{Enum.count(subscriber.plan.recharges)}"
      IO.puts "========================================"
    end)

    Subscriber.pospaid_subscribers()
    |> Enum.each(fn subscriber ->
      subscriber = Pospaid.print_bill(month, year, subscriber.number)
      IO.puts "Pospaid account from subscriber: #{subscriber.name}"
      IO.puts "Number: #{subscriber.number}"
      IO.puts "Calls: "
      IO.inspect(subscriber.calls)
      IO.puts "Total calls: #{Enum.count(subscriber.calls)}"
      IO.puts "Bill value: #{subscriber.plan.value}"
      IO.puts "========================================"
    end)
  end
end
