
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.StringTokenizer;

public class bohem
{
	public static String getenv(String name)
	{
		try {
			Process p;
			BufferedReader br;

			p = Runtime.getRuntime().exec("env");
			br = new BufferedReader(new InputStreamReader(p.getInputStream()));

			try {
		 		String s;
				String vn;
				StringTokenizer st;

				s = br.readLine();
				while(s != null) {
					st = new StringTokenizer(s,"=");
					vn = st.nextToken();
					if(name.equals(vn)) {
						return st.nextToken();
					}
					s = br.readLine();
				}
			} catch(Exception e) {
				System.out.println("End of input");
			}
		} catch(Exception e) {
			System.out.println("getenv(" + name + ") failed");
		}
		return "";
	}
	public static void log_pass(String details)
	{
		String testname;

		testname = getenv("TC_NAME");
		System.out.println("TESTPASSED: " + testname + " " + details);
	}
	public static void log_fail(String details)
	{
		String testname;

		testname = getenv("TC_NAME");
		System.out.println("TESTFAILED: " + testname + " " + details);
	}
}
