import java.security.Provider;
import java.security.Security;

public class ProviderTest {
	public static void main(String[] args) {
		String name = "SunPKCS11-Solaris";

		Provider prov = Security.getProvider(name);
		if (prov != null) {
			System.out.println("PKCS11 found");
			System.out.println(prov.getName());
			System.exit(2);
		}
	}
}
