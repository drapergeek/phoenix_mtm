defmodule PhoenixMTM.Changeset do
  @moduledoc """
  Provides many_to_many helpers for Ecto Changesets.
  """

  import Ecto.Changeset, only: [put_assoc: 3]

  @doc """
  Cast a collection of IDs into a many_to_many association.


  ## Example

      schema "models" do
        many_to_many :tags, App.Tag,
          join_through: App.TagToModel,
          on_delete: :delete_all,
          on_replace: :delete
      end

      def changeset(model, params \\ %{}) do
        model
        |> cast(params, ~w())
        |> PhoenixMTM.Changeset.cast_collection(:tags, App.Repo, App.Tag)
      end

  """
  def cast_collection(set, assoc, repo, mod) do
    case Map.fetch(set.params, to_string(assoc)) do
      {:ok, ids} ->
        changes =
          ids
          |> Enum.filter(&not_nil/1)
          |> Enum.map(fn id ->
            # FIXME: Can we skip the get! somehow?
            mod.changeset(repo.get!(mod, id), %{})
          end)

        put_assoc(set, assoc, changes)
      :error ->
        put_assoc(set, assoc, [])
    end
  end

  defp not_nil(value), do: !is_nil(value)
end
