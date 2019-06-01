
class GreeterApplicationTest : TestCase {
	private Webkit2gtkGreeter.GreeterApplication? test_article = null;
	public GreeterApplicationTest() {
		base("GreeterApplicationTest");
	}
	public override void set_up() {
		Webkit2gtkGreeter.AppOptions opts = {false};
		this.test_article = new Webkit2gtkGreeter.GreeterApplication(opts);
	}
	public override void tear_down() {
		this.test_article = null;
	}
}
