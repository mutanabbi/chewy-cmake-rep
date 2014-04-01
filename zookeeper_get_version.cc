#include <iostream>
#include <zookeeper/zookeeper.h>

int main()
{
    // Show ZooKeeper version as a result...
    std::cout << ZOO_MAJOR_VERSION << '.' << ZOO_MINOR_VERSION << '.' << ZOO_PATCH_VERSION;
    return 0;
}
