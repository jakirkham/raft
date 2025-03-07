/*
 * Copyright (c) 2019-2024, NVIDIA CORPORATION.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#pragma once

#include <raft/sparse/coo.hpp>
#include <raft/sparse/detail/cusparse_wrappers.h>
#include <raft/sparse/detail/utils.h>
#include <raft/util/cuda_utils.cuh>
#include <raft/util/cudart_utils.hpp>

#include <cuda_runtime.h>
#include <thrust/device_ptr.h>
#include <thrust/scan.h>

#include <cusparse_v2.h>

#include <algorithm>
#include <iostream>

namespace raft {
namespace sparse {
namespace convert {
namespace detail {

template <typename value_idx = int, int TPB_X = 32>
RAFT_KERNEL csr_to_coo_kernel(const value_idx* row_ind,
                              value_idx m,
                              value_idx* coo_rows,
                              value_idx nnz)
{
  // row-based matrix 1 thread per row
  value_idx row = (blockIdx.x * TPB_X) + threadIdx.x;
  if (row < m) {
    value_idx start_idx = row_ind[row];
    value_idx stop_idx  = get_stop_idx(row, m, nnz, row_ind);
    for (value_idx i = start_idx; i < stop_idx; i++)
      coo_rows[i] = row;
  }
}

/**
 * @brief Convert a CSR row_ind array to a COO rows array
 * @param row_ind: Input CSR row_ind array
 * @param m: size of row_ind array
 * @param coo_rows: Output COO row array
 * @param nnz: size of output COO row array
 * @param stream: cuda stream to use
 */
template <typename value_idx = int, int TPB_X = 32>
void csr_to_coo(
  const value_idx* row_ind, value_idx m, value_idx* coo_rows, value_idx nnz, cudaStream_t stream)
{
  // @TODO: Use cusparse for this.
  dim3 grid(raft::ceildiv(m, (value_idx)TPB_X), 1, 1);
  dim3 blk(TPB_X, 1, 1);

  csr_to_coo_kernel<value_idx, TPB_X><<<grid, blk, 0, stream>>>(row_ind, m, coo_rows, nnz);

  RAFT_CUDA_TRY(cudaGetLastError());
}

};  // end NAMESPACE detail
};  // end NAMESPACE convert
};  // end NAMESPACE sparse
};  // end NAMESPACE raft
