defmodule OffBroadway.Splunk.Options do
  @moduledoc """
  OffBroadway Splunk option definitions and custom validators.
  """

  def definition do
    [
      sid: [
        required: true,
        type: {
          :custom,
          __MODULE__,
          :type_non_empty_string,
          [[{:name, :sid}]]
        },
        doc: """
        The SID (Search ID) for the Splunk job we want to consume events from.
        """
      ],
      receive_interval: [
        type: :non_neg_integer,
        doc: """
        The duration (in milliseconds) for which the producer waits before
        making a request for more messages.
        """,
        default: 5000
      ],
      splunk_client: [
        doc: """
        A module that implements the `OffBroadway.Splunk.Client` behaviour.
        This module is responsible for fetching and acknowledging the messages
        from Splunk. All options passed to the producer will also be forwarded to
        the client.
        """,
        default: OffBroadway.Splunk.SplunkClient
      ],
      config: [
        type: :keyword_list,
        keys: [
          base_url: [type: :string, doc: "Base URL to Splunk instance."],
          api_token: [
            type: :string,
            doc: "API token used to authenticate on the Splunk instance."
          ]
        ],
        doc: """
        A set of config options that overrides the default config for the `splunk_client`
        module. Any option set here can also be configured in `config.exs`.
        """,
        default: []
      ]
    ]
  end

  def type_non_empty_string("", [{:name, name}]),
    do: {:error, "expected :#{name} to be a non-empty string, got: \"\""}

  def type_non_empty_string(value, _) when not is_nil(value) and is_binary(value),
    do: {:ok, value}

  def type_non_empty_string(value, [{:name, name}]),
    do: {:error, "expected :#{name} to be a non-empty string, got: #{inspect(value)}"}

  def type_splunk_client_module(nil, _), do: {:ok, OffBroadway.Splunk.SplunkClient}
end
