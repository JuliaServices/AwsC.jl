module LibAwsC

using aws_c_common_jll
# const libaws_c_common = "/Users/jacob.quinn/aws-crt/lib/libaws-c-common.1.0.0.dylib"

const aws_allocator = Cvoid

const AWS_OP_SUCCESS = 0
const AWS_OP_ERR = -1

function aws_default_allocator()
    @ccall libaws_c_common.aws_default_allocator()::Ptr{aws_allocator}
end

function aws_common_library_init(allocator)
    @ccall libaws_c_common.aws_common_library_init(allocator::Ptr{aws_allocator})::Cint
end

function aws_mem_calloc(allocator, num, size)
    @ccall libaws_c_common.aws_mem_calloc(allocator::Ptr{aws_allocator}, num::Csize_t, size::Csize_t)::Ptr{Cvoid}
end

function aws_mem_acquire(allocator, size)
    @ccall libaws_c_common.aws_mem_acquire(allocator::Ptr{aws_allocator}, size::Csize_t)::Ptr{Cvoid}
end

function aws_mem_release(allocator, ptr)
    @ccall libaws_c_common.aws_mem_release(allocator::Ptr{aws_allocator}, ptr::Ptr{Cvoid})::Cvoid
end

function aws_last_error()
    @ccall libaws_c_common.aws_last_error()::Cint
end

function aws_error_str(err)
    unsafe_string(@ccall libaws_c_common.aws_error_str(err::Cint)::Ptr{Cchar})
end

aws_throw_error() = error(aws_error_str(aws_last_error()))

@enum aws_log_level::UInt32 begin
    AWS_LL_NONE = 0
    AWS_LL_FATAL = 1
    AWS_LL_ERROR = 2
    AWS_LL_WARN = 3
    AWS_LL_INFO = 4
    AWS_LL_DEBUG = 5
    AWS_LL_TRACE = 6
    AWS_LL_COUNT = 7
end

const aws_logger = Cvoid

mutable struct aws_logger_standard_options
    level::aws_log_level
    filename::Ptr{Cchar}
    file::Libc.FILE
end

aws_logger_standard_options(level, file) = aws_logger_standard_options(aws_log_level(level), C_NULL, file)

function aws_logger_set_log_level(logger, level)
    @ccall libaws_c_common.aws_logger_set_log_level(logger::Ptr{aws_logger}, level::aws_log_level)::Cint
end

function aws_logger_init_standard(logger, allocator, options)
    @ccall libaws_c_common.aws_logger_init_standard(logger::Ptr{aws_logger}, allocator::Ptr{aws_allocator}, options::Ref{aws_logger_standard_options})::Cint
end

function aws_logger_set(logger)
    @ccall libaws_c_common.aws_logger_set(logger::Ptr{aws_logger})::Cvoid
end

const ALLOCATOR = Ref{Ptr{Cvoid}}(C_NULL)
const LOGGER = Ref{Ptr{Cvoid}}(C_NULL)

#NOTE: this is global process logging in the aws-crt libraries; not appropriate for request-level
# logging, but more for debugging the library itself
function set_log_level!(level::Integer)
    @assert 0 <= level <= 7 "log level must be between 0 and 7"
    aws_logger_set_log_level(LOGGER[], aws_log_level(level)) != 0 && aws_throw_error()
    return
end

struct aws_byte_cursor
    len::Csize_t
    ptr::Ptr{UInt8}
end

aws_byte_cursor(x::String) = aws_byte_cursor_from_c_str(x)

function aws_byte_cursor_from_c_str(c_str)
    @ccall libaws_c_common.aws_byte_cursor_from_c_str(c_str::Cstring)::aws_byte_cursor
end

struct aws_byte_buf
    len::Csize_t
    buffer::Ptr{UInt8}
    capacity::Csize_t
    allocator::Ptr{aws_allocator}
end

function aws_byte_buf_append(to::aws_byte_buf, from::aws_byte_cursor)
    ref = Ref(to)
    ret = @ccall libaws_c_common.aws_byte_buf_append(ref::Ref{aws_byte_buf}, from::Ref{aws_byte_cursor})::Cint
    ret != 0 && aws_throw_error()
    return ref[]
end

function aws_byte_cursor_from_buf(buf::aws_byte_buf)
    @ccall libaws_c_common.aws_byte_cursor_from_buf(buf::Ref{aws_byte_buf})::aws_byte_cursor
end

precompiling() = ccall(:jl_generating_output, Cint, ()) == 1

function __init__()
    if !precompiling()
        # populate default allocator
        ALLOCATOR[] = aws_default_allocator()
        @assert ALLOCATOR[] != C_NULL
        aws_common_library_init(ALLOCATOR[])
        # initialize logger
        LOGGER[] = aws_mem_acquire(ALLOCATOR[], 64)
        # change the 1st arg `0` to something higher to enable logging
        log_options = aws_logger_standard_options(0, Libc.FILE(Libc.RawFD(1), "w"))
        aws_logger_init_standard(LOGGER[], ALLOCATOR[], log_options) != 0 && aws_throw_error()
        aws_logger_set(LOGGER[])
    end
    return
end

end