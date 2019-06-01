int main(string[] args) {
/*
 * Hook up all tests into appropriate suites
 */

	TestSuite client = new TestSuite("client");
	client.add_suite(new GreeterApplicationTest().get_suite());

	/*
	 * Run the tests
	 */
	TestSuite root = TestSuite.get_root();
	root.add_suite(client);

	int ret = -1;
	Idle.add(() => {
		ret = Test.run();
		Gtk.main_quit();
		return false;
	});

	Gtk.main();
	return ret;
}
