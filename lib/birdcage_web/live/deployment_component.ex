defmodule DeploymentComponent do
  @moduledoc false

  use BirdcageWeb, :live_component

  def toggle_class_bg(true = _on), do: "bg-green-400"
  def toggle_class_bg(false = _on), do: "bg-red-400"

  def toggle_class_border(true = _on), do: "translate-x-full border-green-400"
  def toggle_class_border(false = _on), do: "translate-x-0 border-red-400"
end
