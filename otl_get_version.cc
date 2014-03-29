#include <iostream>
#include <otlv4.h>

int main()
{
    const unsigned major = (OTL_VERSION_NUMBER & 0xff0000) >> 16;
    const unsigned minor = (OTL_VERSION_NUMBER & 0xff00) >> 8;
    const unsigned patch = (OTL_VERSION_NUMBER & 0xff);
    std::cout << major << '.' << minor << '.' << patch;
    return 0;
}
