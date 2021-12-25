cmake_minimum_required(VERSION 3.12)
project(rust VERSION 0.0.1 LANGUAGES CXX)

find_package(Corrosion REQUIRED)

corrosion_import_crate(MANIFEST_PATH Cargo.toml)
