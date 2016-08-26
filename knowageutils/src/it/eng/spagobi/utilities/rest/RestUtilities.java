/*
 * Knowage, Open Source Business Intelligence suite
 * Copyright (C) 2016 Engineering Ingegneria Informatica S.p.A.
 * 
 * Knowage is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Knowage is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package it.eng.spagobi.utilities.rest;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.Proxy;
import java.net.ProxySelector;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpException;
import org.apache.commons.httpclient.HttpMethodBase;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.URIException;
import org.apache.commons.httpclient.methods.DeleteMethod;
import org.apache.commons.httpclient.methods.EntityEnclosingMethod;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.httpclient.methods.PutMethod;
import org.apache.commons.httpclient.util.ParameterParser;
import org.apache.commons.httpclient.util.URIUtil;
import org.apache.htrace.fasterxml.jackson.databind.jsonFormatVisitors.JsonAnyFormatVisitor;
import org.apache.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.hazelcast.com.eclipsesource.json.JsonObject;

import it.eng.spagobi.utilities.assertion.Assert;
import it.eng.spagobi.utilities.exceptions.SpagoBIRuntimeException;
import it.eng.spagobi.utilities.filters.XSSRequestWrapper;
import it.eng.spagobi.utilities.json.JSONUtils;

public class RestUtilities {

	private final static Logger log = Logger.getLogger(RestUtilities.class);
	private static final String DEFAULT_CHARSET = "UTF-8";
	public static final String CONTENT_TYPE = "Content-Type";

	private static String proxyAddress;
	private static int proxyPort;

	/**
	 * Fort testing purpose
	 *
	 * @param proxyAddress
	 */
	public static void setProxyAddress(String proxyAddress) {
		RestUtilities.proxyAddress = proxyAddress;
	}

	/**
	 * Fort testing purpose
	 *
	 * @param proxyPort
	 */
	public static void setProxyPort(int proxyPort) {
		RestUtilities.proxyPort = proxyPort;
	}

	/**
	 * @deprecated 
	 * This function could give problem with XSS. <br/>
	 * Inplace of this, please use one of <br/>
	 * {@link #readBodyAsJSONObject(HttpServletRequest request)} which returns a JSONObject <br/>
	 * {@link #readBodyAsJSONArray(HttpServletRequest request)} which returns a JSONArray <br/>
	 * {@link #readBodyXSSUnsafe(HttpServletRequest request)} which returns a String <br/>
	 *
	 */
	@Deprecated
	public static String readBody(HttpServletRequest request) throws IOException {
		return readBodyXSSUnsafe(request);
	}

	/**
	 * Reads the body of a request and return it as a string<br/>
	 *
	 * <b>Warning:</b> this method does not provide protection against 
	 * XSS attaks. Use it only if you know what you are doing. 
	 *
	 * @param request
	 *            the HttpServletRequest request
	 * @return the body
	 * @throws IOException
	 */
	public static String readBodyXSSUnsafe(HttpServletRequest request) throws IOException {
		StringBuilder stringBuilder = new StringBuilder();
		BufferedReader bufferedReader = null;
		try {
			InputStream inputStream = request.getInputStream();
			if (inputStream != null) {
				bufferedReader = new BufferedReader(new InputStreamReader(inputStream));
				char[] charBuffer = new char[128];
				int bytesRead = -1;
				while ((bytesRead = bufferedReader.read(charBuffer)) > 0) {
					stringBuilder.append(charBuffer, 0, bytesRead);
				}
			} else {
				stringBuilder.append("");
			}
		} finally {
			if (bufferedReader != null) {
				bufferedReader.close();
			}
		}
		return stringBuilder.toString();
	}

	/**
	 *
	 * Reads the body of a request and return it as a JSONObject
	 * <b>Fiters content against XSS attacks</b>
	 *
	 * @param request
	 *            the HttpServletRequest request
	 * @return
	 * @throws IOException
	 * @throws JSONException
	 */
	public static JSONObject readBodyAsJSONObject(HttpServletRequest request) throws IOException, JSONException {
		String requestBody = RestUtilities.readBodyXSSUnsafe(request);
		if (requestBody == null || requestBody.equals("")) {
			return new JSONObject();
		}
		final JSONObject jsonObject = new JSONObject(requestBody);

		stripXSSJsonObject(jsonObject);
		
		return jsonObject;
	}

	/**
	 *
	 * Reads the body of a request and return it as a JSONOArray
	 * <b>Fiters content against XSS attacks</b>
	 *
	 * @param request
	 *            the HttpServletRequest request
	 * @return
	 * @throws IOException
	 * @throws JSONException
	 */
	public static JSONArray readBodyAsJSONArray(HttpServletRequest request) throws IOException, JSONException {
		String requestBody = RestUtilities.readBodyXSSUnsafe(request);
		return (JSONArray) stripXSSJsonObject(JSONUtils.toJSONArray(requestBody));
	}

	private static Object stripXSSJsonObject(Object o) throws JSONException {
		if(o instanceof JSONObject) {
			JSONObject inJsonObject = (JSONObject) o;
			final Iterator<String> keys = inJsonObject.keys();
			while(keys.hasNext()) {
				final String key = keys.next();
				final Object object = inJsonObject.get(key);
				if(object instanceof String) {
					inJsonObject.put(key, XSSRequestWrapper.stripXSS((String)object));
				}
				else if (object instanceof JSONObject) {
					stripXSSJsonObject((JSONObject)object);
				}
				else if (object instanceof JSONArray) {
					JSONArray ja = (JSONArray)object;
					for (int i = 0; i < ja.length() ; i++) {
						ja.put(i, stripXSSJsonObject(ja.get(i)));
					}
				}
			}
		}
		else if(o instanceof JSONObject) {
			o = XSSRequestWrapper.stripXSS((String)o);
		}
		else if (o instanceof JSONArray) {
			JSONArray ja = (JSONArray)o;
			for (int i = 0; i < ja.length() ; i++) {
				ja.put(i, stripXSSJsonObject(ja.get(i)));
			}
		}
		return o;
	}

	public static enum HttpMethod {
		Get, Post, Put, Delete
	}

	private static HttpMethodBase getMethod(HttpMethod method, String address) {
		String addr = address;
		if (method.equals(HttpMethod.Delete)) {
			return new DeleteMethod(addr);
		}
		if (method.equals(HttpMethod.Post)) {
			return new PostMethod(addr);
		}
		if (method.equals(HttpMethod.Get)) {
			return new GetMethod(addr);
		}
		if (method.equals(HttpMethod.Put)) {
			return new PutMethod(addr);
		}
		Assert.assertUnreachable("method doesn't exist");
		return null;
	}

	public static class Response {
		private final String responseBody;
		private final int statusCode;

		public Response(String responseBody, int statusCode) {
			this.responseBody = responseBody;
			this.statusCode = statusCode;
		}

		public String getResponseBody() {
			return responseBody;
		}

		public int getStatusCode() {
			return statusCode;
		}

	}

	public static Response makeRequest(HttpMethod httpMethod, String address, Map<String, String> requestHeaders, String requestBody)
			throws HttpException, IOException {
		return makeRequest(httpMethod, address, requestHeaders, requestBody, null);
	}

	@SuppressWarnings("deprecation")
	public static Response makeRequest(HttpMethod httpMethod, String address, Map<String, String> requestHeaders, String requestBody,
			List<NameValuePair> queryParams) throws HttpException, IOException {
		HttpMethodBase method = getMethod(httpMethod, address);
		for (Entry<String, String> entry : requestHeaders.entrySet()) {
			method.addRequestHeader(entry.getKey(), entry.getValue());
		}
		if (queryParams != null) {
			// add uri query params to provided query params present in query
			List<NameValuePair> addressPairs = getAddressPairs(address);
			List<NameValuePair> totalPairs = new ArrayList<NameValuePair>(addressPairs);
			totalPairs.addAll(queryParams);
			method.setQueryString(totalPairs.toArray(new NameValuePair[queryParams.size()]));
		}
		if (method instanceof EntityEnclosingMethod) {
			EntityEnclosingMethod eem = (EntityEnclosingMethod) method;
			// charset of request currently not used
			eem.setRequestBody(requestBody);
		}

		try {
			HttpClient client = new HttpClient();
			setHttpClientProxy(client, address);
			int statusCode = client.executeMethod(method);
			String res = method.getResponseBodyAsString();
			return new Response(res, statusCode);
		} finally {
			method.releaseConnection();
		}
	}

	private static void setHttpClientProxy(HttpClient client, String address) {
		if (proxyAddress != null) {
			Assert.assertTrue(proxyPort != 0, "proxyPort!=0");
			client.getHostConfiguration().setProxy(proxyAddress, proxyPort);
			return;
		}
		// get the proxy from JVM proxy properties
		String proxyHost = null;
		try {
			proxyHost = System.getProperty("http.proxyHost");
		} catch (SecurityException e) {
			log.warn("Proxy can't be retrieved from java configuration", e);
		}
		if (proxyHost == null) {
			return;
		}

		try {
			// check if it's a direct uri for proxy
			List<Proxy> proxies = ProxySelector.getDefault().select(new URI(address));
			if (proxies.size() == 0) {
				return;
			}
			if (proxies.size() == 1 && proxies.get(0).type().equals(Proxy.Type.DIRECT)) {
				return;
			}
		} catch (URISyntaxException e) {
			throw new SpagoBIRuntimeException("Error while proxy selection", e);
		}

		String port = System.getProperty("http.proxyPort");
		Assert.assertTrue(port != null, "port proxy != null");
		int p = Integer.parseInt(port);
		client.getHostConfiguration().setProxy(proxyHost, p);

	}

	@SuppressWarnings("unchecked")
	protected static List<NameValuePair> getAddressPairs(String address) {
		try {
			String query = URIUtil.getQuery(address);
			List<NameValuePair> params = new ParameterParser().parse(query, '&');
			List<NameValuePair> res = new ArrayList<NameValuePair>();
			for (NameValuePair nvp : params) {
				res.add(new NameValuePair(URIUtil.decode(nvp.getName(), DEFAULT_CHARSET), URIUtil.decode(nvp.getValue(), DEFAULT_CHARSET)));
			}
			return res;
		} catch (URIException e) {
			throw new SpagoBIRuntimeException(e);
		}
	}

	public static Map<String, String> getJSONHeaders() {
		Map<String, String> res = new HashMap<String, String>(2);
		res.put("Content-Type", "application/json");
		res.put("Accept", "application/json");
		return res;
	}

	/**
	 * For testing purpose
	 *
	 * @param address
	 * @param port
	 */
	public static void setProxy(String address, int port) {
		setProxyAddress(address);
		setProxyPort(port);
	}

}
