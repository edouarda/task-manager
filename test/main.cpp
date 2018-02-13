#define BOOST_TEST_MODULE "tsk unit test"

#include <boost/test/unit_test.hpp>
// this is how we can ensure fixture destruction order
struct this_global_fixture
{
};

BOOST_GLOBAL_FIXTURE(this_global_fixture);
