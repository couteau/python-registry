vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pypa/pyproject-metadata
    REF ${VERSION}
    SHA512 85b4104cf28610bb7771dc69a1c024bffb3cb51f430aaae0e342af87559c8af9df9fddbf9381c4edeebf396ba1b96582826c6a3a745edb278845949d77375370
    HEAD_REF main
)

vcpkg_python_build_and_install_wheel(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_python_test_import(MODULE "pyproject_metadata")
