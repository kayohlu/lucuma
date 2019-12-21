defmodule Lucuma.Waitlists.AttendanceSmsSetting do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_tags ["[[CANCEL_LINK]]", "[[NAME]]"]

  schema "attendance_sms_settings" do
    field :enabled, :boolean
    field :message_content, :string

    belongs_to :waitlist, Lucuma.Waitlists.Waitlist

    timestamps()
  end

  @doc false
  def changeset(sms_setting, attrs) do
    sms_setting
    |> cast(attrs, [:enabled, :message_content, :waitlist_id])
    |> validate_required([:enabled, :message_content, :waitlist_id])
    |> validate_inclusion(:enabled, [true, false])
    |> validate_matching_braces(:message_content)
    |> validate_tags(:message_content)
  end

  def validate_matching_braces(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, message_content ->
      char_list = String.graphemes(message_content)
      balance_value = balance_the_string(char_list, 0)

      cond do
        balance_value > 0 ->
          [
            {field,
             options[:message] ||
               "You have an extra unnecessary '['. You need to surround your tags with [[ and ]] (double square braces)"}
          ]

        balance_value < 0 ->
          [
            {field,
             options[:message] ||
               "You have an extra unnecessary ']'. You need to surround your tags with [[ and ]] (double square braces)"}
          ]

        true ->
          []
      end
    end)
  end

  def validate_tags(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, message_content ->
      invalid_tags =
        Regex.scan(~r/(\[\[\w+\]\])/, message_content)
        |> List.flatten()
        |> Enum.filter(fn tag -> tag not in @valid_tags end)
        |> Enum.uniq()

      if invalid_tags != [] do
        [
          {field,
           options[:message] ||
             "You have added invalid tags to the message. They are #{Enum.join(invalid_tags, ",")}"}
        ]
      else
        []
      end
    end)
  end

  def balance_the_string([], 0) do
    0
  end

  def balance_the_string([], count) when count != 0 do
    count
  end

  def balance_the_string(char_list, count) do
    [char | rest_of_the_list] = char_list

    cond do
      char == "[" ->
        balance_the_string(rest_of_the_list, count + 1)

      char == "]" ->
        balance_the_string(rest_of_the_list, count - 1)

      # else case
      true ->
        balance_the_string(rest_of_the_list, count)
    end
  end
end
