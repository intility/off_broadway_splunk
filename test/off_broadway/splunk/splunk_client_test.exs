defmodule OffBroadway.Splunk.SplunkClientTest do
  use ExUnit.Case, async: false

  alias Broadway.Message
  alias OffBroadway.Splunk.SplunkClient

  import ExUnit.CaptureLog
  import Tesla.Mock

  @sid1 "8CB53D79-587A-43EE-95CC-14256C65EF95"
  @sid2 "non-existing"
  @sid3 "server-error"

  @message1 %{
    "_bkt" => "my-index~8CB53D79-587A-43EE-95CC-14256C65EF95",
    "_cd" => "329:7062435",
    "_eventtype_color" => "none",
    "_indextime" => "1656323118",
    "_raw" => " {\"field1\": \"some data\", \"field2\": \"more data\"} ",
    "_serial" => "344",
    "_si" => [
      "splunk.example.com",
      "my-index"
    ],
    "_sourcetype" => "my-index",
    "_time" => "2022-06-27T03:20:02.000+02:00",
    "field1" => "some data",
    "field2" => "more data"
  }
  @message2 %{
    "_bkt" => "my-source~8CB53D79-587A-43EE-95CC-14256C65EF95",
    "_cd" => "329:7062366",
    "_eventtype_color" => "none",
    "_indextime" => "1656323118",
    "_raw" => " {\"field1\": \"some other data\", \"field2\": \"more other data\"} ",
    "_serial" => "344",
    "_si" => [
      "splunk.example.com",
      "my-index"
    ],
    "_sourcetype" => "my-index",
    "_time" => "2022-06-27T03:20:02.000+02:00",
    "field1" => "some other data",
    "field2" => "more other data"
  }

  setup do
    mock(fn
      %{method: :get, url: "https://splunk.example.com/services/search/v2/jobs/#{@sid1}/results"} ->
        %Tesla.Env{status: 200, body: %{"results" => [@message1, @message2]}}

      %{method: :get, url: "https://splunk.example.com/services/search/v2/jobs/#{@sid2}/results"} ->
        %Tesla.Env{
          status: 404,
          body: %{"messages" => [%{"type" => "FATAL", "text" => "Unknown sid."}]}
        }

      %{method: :get, url: "https://splunk.example.com/services/search/v2/jobs/#{@sid3}/results"} ->
        {:error, :timeout}

      %{method: :get, url: "https://splunk.example.com/servicesNS/-/-/search/v2/jobs/#{@sid1}/results"} ->
        %Tesla.Env{status: 200, body: %{"results" => [@message1, @message2]}}

      %{method: :get, url: "https://splunk.example.com/servicesNS/-/-/saved/searches/My fine report"} ->
        %Tesla.Env{
          status: 200,
          body: %{"entry" => [%{"acl" => %{"app" => "isoc", "owner" => "aa738"}}]}
        }

      %{method: :get, url: "https://splunk.example.com/servicesNS/nobody/isoc/saved/searches/My fine report/history"} ->
        %Tesla.Env{status: 200, body: %{"entry" => []}}

      %{method: :get, url: "https://splunk.example.com/servicesNS/-/-/saved/searches/Unknown report"} ->
        %Tesla.Env{status: 404, body: %{"messages" => [%{"type" => "ERROR", "text" => "Not found."}]}}
    end)
  end

  describe "receive_messages/3" do
    setup do
      {:ok,
       %{
         base_opts: [
           name: "My fine report",
           config: [
             base_url: "https://splunk.example.com",
             api_token: "secret-api-token",
             api_version: "v2"
           ]
         ]
       }}
    end

    test "init/1 returns normalized client options", %{base_opts: base_opts} do
      assert {:ok,
              [
                base_url: "https://splunk.example.com",
                api_token: "secret-api-token",
                api_version: "v2"
              ]} = SplunkClient.init(base_opts)
    end

    test "returns {:ok, list} of Broadway.Message with :data and :acknowledger set", %{
      base_opts: base_opts
    } do
      {:ok, opts} = SplunkClient.init(base_opts)
      {:ok, [message1, message2]} = SplunkClient.receive_messages(@sid1, 10, opts)

      assert message1.data == @message1
      assert message2.data == @message2

      assert message1.acknowledger ==
               {SplunkClient, nil,
                %{
                  receipt: %{
                    id: "my-index~8CB53D79-587A-43EE-95CC-14256C65EF95;329:7062435",
                    sid: @sid1
                  }
                }}
    end

    test "if the request fails with non-200, returns {:error, {:http_error, status}}", %{
      base_opts: base_opts
    } do
      {:ok, opts} = SplunkClient.init(base_opts)

      assert capture_log(fn ->
               assert {:error, {:http_error, 404}} = SplunkClient.receive_messages(@sid2, 10, opts)
             end) =~ "Unable to fetch events from Splunk SID"
    end

    test "if the request fails with network error, returns {:error, reason}", %{base_opts: base_opts} do
      {:ok, opts} = SplunkClient.init(base_opts)

      assert capture_log(fn ->
               assert {:error, :timeout} = SplunkClient.receive_messages(@sid3, 10, opts)
             end) =~ "Unable to fetch events from Splunk SID"
    end

    test "when use_wildcard_namespace is true, requests events via /servicesNS/-/-", %{
      base_opts: base_opts
    } do
      base_opts = put_in(base_opts, [:config, :use_wildcard_namespace], true)
      {:ok, opts} = SplunkClient.init(base_opts)

      assert {:ok, [_message1, _message2]} = SplunkClient.receive_messages(@sid1, 10, opts)
    end
  end

  describe "receive_status/2" do
    setup do
      {:ok,
       %{
         base_opts: [
           name: "My fine report",
           config: [
             base_url: "https://splunk.example.com",
             api_token: "secret-api-token",
             api_version: "v2"
           ]
         ]
       }}
    end

    test "requests the default /services namespace by default", %{base_opts: base_opts} do
      {:ok, opts} = SplunkClient.init(base_opts)

      assert_raise Tesla.Mock.Error, fn -> SplunkClient.receive_status("My fine report", opts) end
    end

    test "when use_wildcard_namespace is true, resolves the app via a wildcard lookup then fetches history from a concrete namespace",
         %{base_opts: base_opts} do
      base_opts = put_in(base_opts, [:config, :use_wildcard_namespace], true)
      {:ok, opts} = SplunkClient.init(base_opts)

      assert {:ok, %{status: 200, body: %{"entry" => []}}} =
               SplunkClient.receive_status("My fine report", opts)
    end

    test "when use_wildcard_namespace is true and app resolution fails, returns the error", %{
      base_opts: base_opts
    } do
      base_opts =
        base_opts
        |> put_in([:config, :use_wildcard_namespace], true)
        |> Keyword.put(:name, "Unknown report")

      {:ok, opts} = SplunkClient.init(base_opts)

      assert capture_log(fn ->
               assert {:error, {:http_error, 404}} = SplunkClient.receive_status("Unknown report", opts)
             end) =~ "Unable to fetch status for \"Unknown report\""
    end
  end

  describe "ack/3" do
    setup do
      {:ok,
       %{
         base_opts: [
           name: "My fine report",
           config: [
             base_url: "https://splunk.example.com",
             api_token: "secret-api-token"
           ],
           on_success: :ack,
           on_failure: :noop
         ]
       }}
    end

    test "emits a telemetry event when acking messages", %{base_opts: base_opts} do
      self = self()
      {:ok, opts} = SplunkClient.init(base_opts)

      ack_data = %{receipt: %{id: "1", sid: @sid1}}
      fill_persistent_term(opts[:name], base_opts)

      capture_log(fn ->
        :ok =
          :telemetry.attach(
            "ack_test",
            [:off_broadway_splunk, :receive_messages, :ack],
            fn name, measurements, metadata, _ ->
              send(self, {:telemetry_event, name, measurements, metadata})
            end,
            nil
          )
      end)

      SplunkClient.ack(
        opts[:name],
        [%Message{acknowledger: {SplunkClient, opts[:name], ack_data}, data: nil}],
        []
      )

      assert_receive {:telemetry_event, [:off_broadway_splunk, :receive_messages, :ack], %{time: _},
                      %{name: _, receipt: _}}
    end
  end

  defp fill_persistent_term(ack_ref, base_opts) do
    :persistent_term.put(ack_ref, %{
      name: base_opts[:name],
      config: base_opts[:config],
      on_success: base_opts[:on_success] || :ack,
      on_failure: base_opts[:on_failure] || :noop
    })
  end
end
