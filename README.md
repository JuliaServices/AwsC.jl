# AwsC.jl

Wrapper library for the https://github.com/awslabs/aws-c-common library.

The `LibAwsC` module (exported) aims to directly wrap and expose aws-c-common functionality (matching
data structures and api functions exactly).

The functions and structures in `AwsC` are more Julia-like and are intended to be more user-friendly,
while using `LibAwsC` under the hood.

GitHub Actions : [![Build Status](https://github.com/JuliaServices/AwsC.jl/workflows/CI/badge.svg)](https://github.com/JuliaServices/AwsC.jl/actions?query=workflow%3ACI+branch%3Amaster)

[![codecov.io](http://codecov.io/github/JuliaServices/AwsC.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaServices/AwsC.jl?branch=master)
