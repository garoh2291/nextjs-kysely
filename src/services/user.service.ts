import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import api from "./api";
import { DB } from "kysely-codegen";

interface GetUserLoginsParams {
  enabled?: boolean;
  userId?: string;
  limit?: number;
  page?: number;
}

// API Functions
const userApi = {
  getUserLogins: async (params: {
    userId: string;
    limit?: number;
    page?: number;
  }): Promise<DB["user_login"][]> => {
    const queryParams = new URLSearchParams();
    if (params.limit) queryParams.append("limit", params.limit.toString());
    if (params.page) queryParams.append("page", params.page.toString());

    const response = await api.get(
      `/users/${params.userId}/logins?${queryParams}`
    );
    return response.data.data || [];
  },

  getCurrentUser: async (): Promise<DB["user"]> => {
    const response = await api.get("/users/me");
    return response.data.data;
  },

  updateUserProfile: async (
    userData: Partial<DB["user"]>
  ): Promise<DB["user"]> => {
    const response = await api.put("/users/me", userData);
    return response.data.data;
  },
};

// Query Hooks
export const useGetCurrentUser = ({
  enabled = true,
}: {
  enabled?: boolean;
} = {}) => {
  return useQuery({
    queryKey: ["currentUser"],
    enabled,
    queryFn: userApi.getCurrentUser,
    select: (data) => data,
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
};

export const useGetUserLogins = ({
  enabled = true,
  userId,
  limit = 10,
  page = 1,
}: GetUserLoginsParams) => {
  return useQuery({
    queryKey: ["userLogins", userId, limit, page],
    enabled: enabled && !!userId,
    queryFn: () => userApi.getUserLogins({ userId: userId!, limit, page }),
    select: (data) => data,
    staleTime: 2 * 60 * 1000, // 2 minutes
  });
};

// Mutation Hooks
export const useUpdateUserProfile = ({
  onMutate,
  onSuccess,
  onError,
}: {
  onMutate?: () => void;
  onSuccess?: (data: DB["user"]) => void;
  onError?: (error: Error) => void;
} = {}) => {
  const queryClient = useQueryClient();

  return useMutation<DB["user"], Error, Partial<DB["user"]>>({
    mutationFn: userApi.updateUserProfile,
    onMutate: async (newUserData) => {
      // Cancel any outgoing refetches
      await queryClient.cancelQueries({ queryKey: ["currentUser"] });

      // Snapshot the previous value
      const previousUser = queryClient.getQueryData<DB["user"]>([
        "currentUser",
      ]);

      // Optimistically update to the new value
      if (previousUser) {
        queryClient.setQueryData<DB["user"]>(["currentUser"], {
          ...previousUser,
          ...newUserData,
        });
      }

      onMutate?.();

      // Return a context object with the snapshotted value
      return { previousUser };
    },
    onError: (error) => {
      // If the mutation fails, use the context returned from onMutate to roll back

      onError?.(error);
    },
    onSuccess: (data) => {
      // Invalidate and refetch
      queryClient.invalidateQueries({ queryKey: ["currentUser"] });
      onSuccess?.(data);
    },
  });
};
