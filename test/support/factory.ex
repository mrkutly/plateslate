defmodule Factory do
  def create_user(:employee), do: create_user_by_role("employee")
  def create_user(:customer), do: create_user_by_role("customer")

  def create_user_by_role(role) do
    int = :erlang.unique_integer([:positive, :monotonic])

    params = %{
      name: "Person #{int}",
      email: "fake-#{int}@exmaple.com",
      password: "super-secret",
      role: role
    }

    %PlateSlate.Accounts.User{}
    |> PlateSlate.Accounts.User.changeset(params)
    |> PlateSlate.Repo.insert!()
  end
end
