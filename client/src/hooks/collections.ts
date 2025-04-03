import { useContext, useMemo } from "react";
import { CollectionContext } from "../context/collection";
import { useProject } from "./project";

/**
 * Custom hook to access the Collection context and account information.
 * Must be used within a CollectionProvider component.
 *
 * @returns An object containing:
 * - collections: The registered collections
 * - status: The status of the collections
 * @throws {Error} If used outside of a CollectionProvider context
 */
export const useCollections = () => {
  const context = useContext(CollectionContext);
  const { project } = useProject();

  if (!context) {
    throw new Error(
      "The `useCollections` hook must be used within a `CollectionProvider`",
    );
  }

  const { collections: allCollections, status } = context;

  const collections = useMemo(() => {
    if (!project) return allCollections;
    return allCollections.filter((collection) =>
      collection.imageUrl.includes(project),
    );
  }, [project, allCollections]);

  return { collections, status };
};
