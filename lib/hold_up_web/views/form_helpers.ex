defmodule HoldUpWeb.FormHelpers do
  @moduledoc """
  Conveniences for working with forms.
  """

  import Phoenix.HTML.Form
  import Phoenix.HTML.Tag
  import HoldUpWeb.ErrorHelpers

  @doc """
  Generates a form group div for forms.
  """

  def form_group(form, field, opts \\ []) do
    content_tag(:div, class: "form-group") do
      [
        label(form, field, class: "control-label"),
        text_input(form, field, class: input_field_classes(form, field)),
        error_tag(form, field)
      ]
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

  def form_group_custom(form, field, opts \\ [], do: block) do
    content_tag(:div, class: "form-group") do
      [
        label(form, field, class: "control-label"),
        block,
        error_tag(form, field)
      ]
    end
  end


  def password_form_group(form, field, opts \\ []) do
    content_tag(:div, class: "form-group") do
      [
        label(form, field, class: "control-label"),
        password_input(form, field, class: input_field_classes(form, field)),
        error_tag(form, field)
      ]
    end
  end

  def number_form_group(form, field, opts \\ []) do
    content_tag(:div, class: "form-group") do
      [
        label(form, field, class: "control-label"),
        number_input(form, field, class: input_field_classes(form, field)),
        error_tag(form, field)
      ]
    end
  end

  def phone_form_group(form, field, opts \\ []) do
    content_tag(:div, class: "form-group") do
      [
        label(form, field, class: "control-label"),
        text_input(form, field, class: input_field_classes(form, field), id: "input-phone"),
        error_tag(form, field)
      ]
    end
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