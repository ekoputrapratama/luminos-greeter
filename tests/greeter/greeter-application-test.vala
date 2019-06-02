
class GreeterApplicationTest : TestCase {
	private WebkitGtkGreeter.GreeterApplication? test_article = null;
	public GreeterApplicationTest() {
		base("GreeterApplicationTest");
	}
	public override void set_up() {
		WebkitGtkGreeter.AppOptions opts = {false};
		this.test_article = new WebkitGtkGreeter.GreeterApplication(opts);
	}
	public override void tear_down() {
		this.test_article = null;
	}
}
