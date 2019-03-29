defmodule HoldUpWeb.FormHelpers do
  @moduledoc """
  Conveniences for working with forms.

  http://blog.plataformatec.com.br/2016/09/dynamic-forms-with-phoenix/
  """

  import Phoenix.HTML.Form
  import Phoenix.HTML.Tag
  import HoldUpWeb.ErrorHelpers

  @doc """
  Generates a form group div for forms.
  """

  def form_group(form, field, opts \\ []) do
    type = opts[:using] || Phoenix.HTML.Form.input_type(form, field)

    wrapper_opts = Keyword.merge([class: "form-group"], opts[:wrapper_opts] || [])
    label_opts = Keyword.merge([class: "control-label"], opts[:label_opts] || [])
    input_opts = Keyword.merge([class: input_field_classes(form, field)], opts[:input_opts] || [])

    content_tag(:div, wrapper_opts) do
      label = label(form, field, label_opts)
      # apply is like the equivalent of send in ruby.
      input = apply(Phoenix.HTML.Form, type, [form, field, input_opts])
      error = error_tag(form, field)

      [label, input, error]
    end
  end

  def input_group(form, field, opts \\ [], do: block) do
    content_tag(:div, class: "form-group") do
      [
        label(form, field, class: "control-label"),
        content_tag(:div, class: "input-group") do
          block
        end
      ]
    end
  end

  def phone_form_group(form, field, opts \\ []) do
    extra_opts = [
      label_opts: [for: "input-phone"],
      input_opts: [id: "input-phone"]
    ]

    form_group(form, field, extra_opts)
  end

  def input_field_classes(form, field) do
    if errors_for_input?(form, field) do
      "form-control is-invalid"
    else
      "form-control"
    end
  end

  defp errors_for_input?(form, field) do
    Enum.any?(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:div, translate_error(error), class: "invalid-feedback")
    end)
  end
end
