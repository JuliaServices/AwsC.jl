module AwsC

include("LibAwsC.jl")
using .LibAwsC

export LibAwsC

const SUCCESS = LibAwsC.AWS_OP_SUCCESS
const ERROR = LibAwsC.AWS_OP_ERR

allocator() = LibAwsC.aws_default_allocator()

mem_acquire(alloc, size) = LibAwsC.aws_mem_acquire(alloc, size)
mem_release(alloc, ptr) = LibAwsC.aws_mem_release(alloc, ptr)

error_str(err) = LibAwsC.aws_error_str(err)

struct Error <: Exception
    msg::String
end

last_error() = Error(LibAwsC.aws_error_str(LibAwsC.aws_last_error()))
throw_error() = throw(last_error())

byte_buf(n::Integer, ptr::Ptr) = LibAwsC.aws_byte_buf(0, ptr, n, C_NULL)
byte_buf(ptr::Ptr, n::Integer) = LibAwsC.aws_byte_buf(n, ptr, n, C_NULL)

byte_cursor(n::Integer, ptr::Ptr) = LibAwsC.aws_byte_cursor(n, ptr)
byte_cursor(s::String) = LibAwsC.aws_byte_cursor_from_c_str(s)

append(to::LibAwsC.aws_byte_buf, from::LibAwsC.aws_byte_cursor) = LibAwsC.aws_byte_buf_append(to, from)

end