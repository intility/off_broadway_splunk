defmodule OffBroadway.Splunk.SplunkClientTest do
  # use ExUnit.Case, async: true

  # import Tesla.Mock

  # alias OffBroadway.Splunk.SplunkClient

  # setup do
  #   orig_config = Application.get_env(:off_broadway_splunk, :api_client)
  #   Application.put_env(:off_broadway_splunk, :api_client, base_url: "https://splunk.example.com")

  #   mock(fn
  #     %{method: :get, url: "https://splunk.example.com/services/search/jobs"} ->
  #       %Tesla.Env{status: 200, body: "list all search jobs"}

  #     %{method: :get, url: "https://splunk.example.com/services/search/jobs/SID"} ->
  #       %Tesla.Env{status: 200, body: "a search job by SID"}

  #     %{method: :get, url: "https://splunk.example.com/services/search/jobs/SID/results"} ->
  #       %Tesla.Env{status: 200, body: "SID events"}
  #   end)

  #   :ok

  #   on_exit(fn ->
  #     Application.put_env(:off_broadway_splunk, :api_client, orig_config)
  #   end)
  # end

  # test "create client" do
  #   assert %Tesla.Client{} = SplunkClient.client()
  # end

  # test "fetching all search jobs" do
  #   assert {:ok, %Tesla.Env{status: 200, body: "list all search jobs"}} =
  #            SplunkClient.client() |> SplunkClient.search_jobs()
  # end

  # test "fetching search jobs by SID" do
  #   assert {:ok, %Tesla.Env{status: 200, body: "a search job by SID"}} =
  #            SplunkClient.client() |> SplunkClient.search_jobs("SID")
  # end

  # test "fetching all events by SID" do
  #   assert {:ok, %Tesla.Env{status: 200, body: "SID events"}} =
  #            SplunkClient.client() |> SplunkClient.search_results("SID")
  # end
end