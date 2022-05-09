defmodule PospaidTest do
  use ExUnit.Case
  doctest Pospaid

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm("pre.txt")
      File.rm("pre.txt")
    end)
  end

  test "should make a call" do
    Subscriber.register("MrDuck", "000", :pospaid)

    assert Pospaid.make_call("000", DateTime.utc_now(), 5) ==
      {:ok, "Call made successfully"}
  end

  test "should print subscriber's bill" do
    Subscriber.register("MrDuck0", "000", :pospaid)
    date = DateTime.utc_now()
    old_date = ~U[2022-04-30 16:00:05.612085Z]

    Pospaid.make_call("000", date, 3)
    Pospaid.make_call("000", old_date, 3)
    Pospaid.make_call("000", date, 3)
    Pospaid.make_call("000", date, 3)

    subscriber = Subscriber.query_subscriber("000", :pospaid)
    assert Enum.count(subscriber.calls) == 4

    subscriber = Pospaid.print_bill(date.month, date.year, "000")

    assert subscriber.number == "000"
    assert Enum.count(subscriber.calls) == 3
    assert subscriber.plan.value == 12.599999999999998
  end

end
