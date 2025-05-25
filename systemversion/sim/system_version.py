# defines for the system version IP
SYSTEM_VERSION_FPGA_VERSION_OFFSET = 0
SYSTEM_VERSION_FPGA_BUILD_OFFSET = 4
SYSTEM_VERSION_BOARD_VERSION_OFFSET = 8

SYSTEM_VERSION_BOARD_TYPE_OFFSET = 16
SYSTEM_VERSION_BOARD_TYPE_MASK = 0xFFFF0000
SYSTEM_VERSION_BOARD_REV_OFFSET = 0
SYSTEM_VERSION_BOARD_REV_MASK = 0x0000FFFF

SYSTEM_VERSION_FPGA_VERSION_MAJ_OFFSET = 8
SYSTEM_VERSION_FPGA_VERSION_MAJ_MASK = 0x0000FF00
SYSTEM_VERSION_FPGA_VERSION_MIN_OFFSET = 0
SYSTEM_VERSION_FPGA_VERSION_MIN_MASK = 0x000000FF


async def system_version_read_board_type(apb_driver):
    value = await apb_driver.read(SYSTEM_VERSION_BOARD_VERSION_OFFSET)
    return (int.from_bytes(value, byteorder='little') & SYSTEM_VERSION_BOARD_TYPE_MASK) >> SYSTEM_VERSION_BOARD_TYPE_OFFSET

async def system_version_read_board_rev(apb_driver):
    value = await apb_driver.read(SYSTEM_VERSION_BOARD_VERSION_OFFSET)
    return (int.from_bytes(value, byteorder='little') & SYSTEM_VERSION_BOARD_REV_MASK) >> SYSTEM_VERSION_BOARD_REV_OFFSET

async def system_version_fpga_version_maj(apb_driver):
    value = await apb_driver.read(SYSTEM_VERSION_FPGA_VERSION_OFFSET)
    return (int.from_bytes(value, byteorder='little') & SYSTEM_VERSION_FPGA_VERSION_MAJ_MASK) >> SYSTEM_VERSION_FPGA_VERSION_MAJ_OFFSET

async def system_version_fpga_version_min(apb_driver):
    value = await apb_driver.read(SYSTEM_VERSION_FPGA_VERSION_OFFSET)
    return (int.from_bytes(value, byteorder='little') & SYSTEM_VERSION_FPGA_VERSION_MIN_MASK) >> SYSTEM_VERSION_FPGA_VERSION_MIN_OFFSET

async def system_version_fpga_version_build(apb_driver):
    value = await apb_driver.read(SYSTEM_VERSION_FPGA_BUILD_OFFSET)
    return int.from_bytes(value, byteorder='little')