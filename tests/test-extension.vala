using LuminosGreeter.Utility;

public static int main(string[] args) {
	Test.init(ref args);
/*
 * Hook up all tests into appropriate suites
 */

	TestSuite extension = new TestSuite("extension");
	extension.add_suite(new UtilsTest().get_suite());

	/*
	 * Run the tests
	 */
	TestSuite root = TestSuite.get_root();
	root.add_suite(extension);

	return Test.run();
}
