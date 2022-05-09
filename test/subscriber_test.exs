defmodule SubscriberTest do
  use ExUnit.Case
  doctest Subscriber

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  describe "subscriber register tests" do
    test "create a prepaid account" do
      assert Subscriber.register("MrDuck", "000", :prepaid) ==
        {:ok, "Subscriber registered!"}
    end

    test "should return an error, because the subscriber is already registed" do
      Subscriber.register("MrDuck", "000", :prepaid)
      assert Subscriber.register("MrDuck", "000", :prepaid) ==
        {:error, "This subscriber already exists!"}
    end
  end

  describe "subscriber queries tests" do
    test "query prepaid" do
      Subscriber.register("MrDuck_prepaid", "000", :prepaid)
      assert Subscriber.query_subscriber("000", :prepaid).name == "MrDuck_prepaid"
      assert Subscriber.query_subscriber("000", :prepaid).plan.__struct__ == Prepaid
    end

    test "query pospaid" do
      Subscriber.register("MrDuck_pospaid", "000", :pospaid)
      assert Subscriber.query_subscriber("000", :pospaid).name == "MrDuck_pospaid"
    end

    test "query all" do
      Subscriber.register("MrDuck_all", "000", :prepaid)
      assert Subscriber.query_subscriber("000").name == "MrDuck_all"
    end
  end

  describe "delete" do
    test "delete subscriber" do
      Subscriber.register("MrDuck_delete", "000", :prepaid)
      assert Subscriber.delete_subscriber("000") ==
        {
          %Subscriber{calls: [], name: "MrDuck_delete", number: "000", plan: %Prepaid{credits: 0, recharges: []}},
          []
        }
    end
  end

end
