defmodule MyAppWeb.UserJSON do
  alias MyApp.Auth.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      password: user.password,
      is_active: user.is_active
    }
  end
  def render("user.json", %{user: user}) do
    %{id: user.id, email: user.email, is_active: user.is_active}
  end

  def render("sign_in.json", %{user: user}) do
    %{
      data: %{
        user: %{
          id: user.id,
          email: user.email
        }
      }
    }
  end

end
