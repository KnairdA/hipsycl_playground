#include <CL/sycl.hpp>

#include <vector>
#include <iostream>

using T = float;

int main() {
	std::vector<T> a = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
	std::vector<T> b = { 9, 8, 7, 6, 5, 4, 3, 2, 1,  0 };
	std::vector<T> c(10);

	cl::sycl::queue q;

	std::cout
		<< "Running on "
		<< q.get_device().get_info<cl::sycl::info::device::name>()
		<< std::endl;

	cl::sycl::buffer<T> A(a.data(), a.size());
	cl::sycl::buffer<T> B(b.data(), b.size());

	{
		cl::sycl::buffer<T> C(c.data(), c.size());

		q.submit([&](cl::sycl::handler &cgh) {
			auto ka = A.get_access<cl::sycl::access::mode::read>(cgh);
			auto kb = B.get_access<cl::sycl::access::mode::read>(cgh);
			auto kc = C.get_access<cl::sycl::access::mode::write>(cgh);

			cgh.parallel_for<class vector_add>(
				cl::sycl::range<1>{10},
				[=](cl::sycl::id<1> index) {
					kc[index] = ka[index] + kb[index];
				}
			);
		});
	}

	std::cout << std::endl << "Result:" << std::endl;

	for (auto elem : c) {
		std::cout << elem << " ";
	}
	std::cout << std::endl;
}
