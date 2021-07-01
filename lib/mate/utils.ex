defmodule Mate.Utils do
  @moduledoc """
  This module contains some small helper utilities.
  """
  import Macro, only: [camelize: 1]

  @spec otp_app() :: atom()
  def otp_app do
    Mix.Project.config() |> Keyword.fetch!(:app)
  end

  @spec module() :: String.t()
  def module do
    otp_app = otp_app()

    case Application.get_env(otp_app, :namespace, otp_app) do
      ^otp_app -> otp_app |> to_string() |> camelize()
      mod -> mod |> inspect()
    end
  end

  @spec module_name(map() | atom() | String.t()) :: String.t()
  def module_name(%module{}), do: module_name(module)

  def module_name(module) when not is_binary(module) do
    module |> to_string |> module_name
  end

  def module_name("Elixir." <> module), do: module_name(module)
  def module_name(module), do: module

  @spec random_id() :: String.t()
  @spec random_id(integer()) :: String.t()
  def random_id(len \\ 32) do
    :crypto.strong_rand_bytes(len) |> Base.hex_encode32(padding: false)
  end

  @spec empty?(nil | String.t()) :: boolean()
  def empty?(string) when is_binary(string), do: String.trim("#{string}") == ""
  def empty?(nil), do: true
  def empty?(_), do: false
end
