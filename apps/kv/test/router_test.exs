defmodule KV.RouterTest do
  use ExUnit.Case, async: true

  test "route requests across nodes" do
    assert KV.Router.route("hello", Kernel, :node, []) ==
      :"foo@aetherus-Inspiron-7420"

    assert KV.Router.route("world", Kernel, :node, []) ==
      :"bar@aetherus-Inspiron-7420"
  end

  test "raises on unknown entries" do
    assert_raise RuntimeError, ~r/could not find entry/i, fn ->
      KV.Router.route(<<0>>, Kernel, :node, [])
    end
  end
end
