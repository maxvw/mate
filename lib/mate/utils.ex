defmodule Mate.Utils do
  import Macro, only: [camelize: 1]

  def otp_app do
    Mix.Project.config() |> Keyword.fetch!(:app)
  end

  def module do
    otp_app = otp_app()

    case Application.get_env(otp_app, :namespace, otp_app) do
      ^otp_app -> otp_app |> to_string() |> camelize()
      mod -> mod |> inspect()
    end
  end

  def module_name(%module{}), do: module_name(module)

  def module_name(module) when not is_binary(module) do
    module |> to_string |> module_name
  end

  def module_name("Elixir." <> module), do: module_name(module)
  def module_name(module), do: module

  def random_id(len \\ 32) do
    :crypto.strong_rand_bytes(len) |> Base.hex_encode32(padding: false)
  end
end
