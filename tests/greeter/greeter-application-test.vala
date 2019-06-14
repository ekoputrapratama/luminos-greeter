
class GreeterApplicationTest : TestCase {
	private Luminos.GreeterApplication? test_article = null;
	public GreeterApplicationTest() {
		base("GreeterApplicationTest");
	}
	public override void set_up() {
		Luminos.AppOptions opts = {false};
		this.test_article = new Luminos.GreeterApplication(opts);
	}
	public override void tear_down() {
		this.test_article = null;
	}
}
