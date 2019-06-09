
class GreeterApplicationTest : TestCase {
	private LuminosGreeter.GreeterApplication? test_article = null;
	public GreeterApplicationTest() {
		base("GreeterApplicationTest");
	}
	public override void set_up() {
		LuminosGreeter.AppOptions opts = {false};
		this.test_article = new LuminosGreeter.GreeterApplication(opts);
	}
	public override void tear_down() {
		this.test_article = null;
	}
}
