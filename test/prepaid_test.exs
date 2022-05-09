defmodule PrepaidTest do
  use ExUnit.Case
  doctest Prepaid

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm("pre.txt")
      File.rm("pre.txt")
    end)
  end

  describe "prepaid functions" do
    test "make call and have enough credits" do
      Subscriber.register("MrDuck0", "000", :prepaid)
      Recharge.new(DateTime.utc_now(), 25, "000")

      assert Prepaid.make_call("000", DateTime.utc_now(), 5) ==
        {:ok, "This call costs $7.25 and you have $17.75 credits"}
    end

    test "make a long call without enought credits" do
      Subscriber.register("MrDuck", "000", :prepaid)
      assert Prepaid.make_call("000", DateTime.utc_now(), 50) ==
        {:error, "Insufficient credits, make a recharge!"}
    end
  end

  describe "tests for print bills" do
    test "informs the bill of month" do
      Subscriber.register("MrDuck0", "000", :prepaid)
      date = DateTime.utc_now()
      old_date = ~U[2022-04-30 16:00:05.612085Z]
      Recharge.new(date, 10, "000")
      Prepaid.make_call("000", date, 3)
      Recharge.new(old_date, 10, "000")
      Prepaid.make_call("000", old_date, 3)

      subscriber = Subscriber.query_subscriber("000", :prepaid)
      assert Enum.count(subscriber.calls) == 2
      assert Enum.count(subscriber.plan.recharges) == 2

      subscriber = Prepaid.print_bill(date.month, date.year, "000")

      assert subscriber.number == "000"
      assert Enum.count(subscriber.calls) == 1
      assert Enum.count(subscriber.plan.recharges) == 1
    end
  end

end
