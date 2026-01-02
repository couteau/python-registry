vcpkg_from_pythonhosted(
    OUT_SOURCE_PATH SOURCE_PATH
    PACKAGE_NAME    llvmlite
    VERSION         ${VERSION}
    SHA512          abb59e8edea3d7e162d7bb2eb4792f1e10baf961d1bd55caad5e309b7ef9c059877924ac8f731ab753d773bf7f68020f1bf2a1c7e8d504dc958775610adff126
)

vcpkg_python_build_and_install_wheel(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
vcpkg_python_test_import(MODULE "llvmlite")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
