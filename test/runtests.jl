using Test, AwsC

@testset "AwsC" begin

alloc = AwsC.allocator()
@test alloc isa Ptr{LibAwsC.aws_allocator}
mem = AwsC.mem_acquire(alloc, 10)
@test mem isa Ptr{Cvoid}
AwsC.mem_release(alloc, mem)

mem = AwsC.mem_acquire(alloc, 10)
bb = AwsC.byte_buf(10, mem)
bc = AwsC.byte_cursor("1234567890")
AwsC.append(bb, bc)
@test unsafe_string(Ptr{UInt8}(mem), 10) == "1234567890"
AwsC.mem_release(alloc, mem)

end
