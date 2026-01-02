vcpkg_from_pythonhosted(
    OUT_SOURCE_PATH SOURCE_PATH
    PACKAGE_NAME    numba
    VERSION         ${VERSION}
    SHA512          1a8ce538182abc5ed60e0756b9f4a736a13bcd33ebc2cb681cb051b1b91f4fe3e8fafa9d6e82d13f9e92c6f3b8316e8c2f739b5a2322b3c092f9c32faebec25f
)
vcpkg_python_build_and_install_wheel(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
vcpkg_python_test_import(MODULE "numba")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
