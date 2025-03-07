#
# Copyright (c) 2021-2024, NVIDIA CORPORATION.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# cython: profile=False
# distutils: language = c++
# cython: embedsignature = True
# cython: language_level = 3

from libcpp.memory cimport shared_ptr

from rmm.librmm.cuda_stream_view cimport cuda_stream_view


cdef extern from "raft/core/interruptible.hpp" namespace "raft" nogil:
    cdef cppclass interruptible:
        void cancel()

cdef extern from "raft/core/interruptible.hpp" \
        namespace "raft::interruptible" nogil:
    cdef void inter_synchronize \
        "raft::interruptible::synchronize"(cuda_stream_view stream) except+
    cdef void inter_yield "raft::interruptible::yield"() except+
    cdef shared_ptr[interruptible] get_token() except+
