defmodule MyAppWeb.UserController do
  use MyAppWeb, :controller

  alias MyApp.Auth
  alias MyApp.Auth.User

  action_fallback MyAppWeb.FallbackController

  def index(conn, _params) do
    users = Auth.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, %{"email" => email, "password" => password}) do
    with {:ok, %User{} = user} <- Auth.create_user(%{email: email, password: password}) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user.id}")
      |> render(:show, user: user)
    else
      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> render(:error, message: "Failed to create user")
    end
  end



  def show(conn, %{"id" => id}) do
    try do
      user = Auth.get_user!(id)
      render(conn, :show, user: user)
    catch
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
    end
  end

def update(conn, %{"id" => id, "email" => email, "password" => password}) do
  user = Auth.get_user!(id)

  with {:ok, %User{} = updated_user} <- Auth.update_user(user, %{email: email, password: password}) do
    render(conn, :show, user: updated_user)
  end
end

  def delete(conn, %{"id" => id}) do
    user = Auth.get_user!(id)

    with {:ok, %User{}} <- Auth.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
  def sign_in(conn, %{"email" => email, "password" => password}) do
      case MyApp.Auth.authenticate_user(email, password) do
        {:ok, user} ->
          conn
          |> put_status(:ok)
          |> put_view(MyAppWeb.UserJSON)
          |> render("sign_in.json", user: user)

        {:error, message} ->
          conn
          |> put_status(:unauthorized)
          |> put_view(MyAppWeb.ErrorJSON)
          |> render("401.json", message: message)
      end
    end
end
