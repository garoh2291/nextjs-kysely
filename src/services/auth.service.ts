import { useMutation, useQuery } from "@tanstack/react-query";
import api from "./api";
import { DB } from "kysely-codegen";

// Types
interface TenantInfo {
  tenant: DB["tenant"];
  userTenant: DB["user_tenant"];
}

interface TrackLoginResponse {
  success: boolean;
}

// API Functions
const authApi = {
  getTenantInfo: async (): Promise<TenantInfo> => {
    const response = await api.get("/user/tenant-info");
    return response.data;
  },

  trackLogin: async (): Promise<TrackLoginResponse> => {
    const response = await api.post("/auth/track-login");
    return response.data;
  },
};

// Query Hooks
export const useGetTenantInfo = ({
  enabled = true,
}: {
  enabled?: boolean;
} = {}) => {
  return useQuery({
    queryKey: ["tenantInfo"],
    enabled,
    queryFn: authApi.getTenantInfo,
    select: (data) => data,
  });
};

// Mutation Hooks
export const useTrackLogin = ({
  onMutate,
  onSuccess,
  onError,
}: {
  onMutate?: () => void;
  onSuccess?: (data: TrackLoginResponse) => void;
  onError?: (error: Error) => void;
} = {}) => {
  return useMutation<TrackLoginResponse, Error, void>({
    mutationFn: authApi.trackLogin,
    onMutate,
    onSuccess,
    onError,
  });
};
