defmodule RechargeTest do
use ExUnit.Case

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm("pre.txt")
      File.rm("pre.txt")
    end)
  end

  test "make a recharge" do
    Subscriber.register("MrDuck", "000", :prepaid)
    Recharge.new(DateTime.utc_now(), 50, "000")

    subscriber = Subscriber.query_subscriber("000", :prepaid)
    assert subscriber.plan.credits == 50
    assert Enum.count(subscriber.plan.recharges) == 1
  end
end
