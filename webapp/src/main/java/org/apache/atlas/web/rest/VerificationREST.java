/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.atlas.web.rest;

import org.apache.atlas.AtlasErrorCode;
import org.apache.atlas.exception.AtlasBaseException;
import org.apache.atlas.model.valid.VerificationResult;
import org.apache.atlas.query.AtlasDSL;
import org.apache.atlas.query.GremlinQuery;
import org.apache.atlas.query.QueryParams;
import org.apache.atlas.repository.Constants;
import org.apache.atlas.type.AtlasTypeRegistry;
import org.apache.atlas.web.util.Servlets;
import org.apache.commons.configuration.Configuration;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;

import javax.inject.Inject;
import javax.inject.Singleton;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;

/**
 * REST interface for data discovery using dsl or full text search
 */
@Path("v2/verify")
@Singleton
@Service
@Consumes({Servlets.JSON_MEDIA_TYPE, MediaType.APPLICATION_JSON})
@Produces({Servlets.JSON_MEDIA_TYPE, MediaType.APPLICATION_JSON})
public class VerificationREST {

    @Context
    private       HttpServletRequest httpServletRequest;
    private final int                maxDslQueryLength;
    private final AtlasTypeRegistry     typeRegistry;

    @Inject
    public VerificationREST(AtlasTypeRegistry typeRegistry, Configuration configuration) {
        this.typeRegistry           = typeRegistry;
        this.maxDslQueryLength      = configuration.getInt(Constants.MAX_DSL_QUERY_STR_LENGTH, 4096);
    }

    /**
     * Retrieve data for the specified DSL
     *
     * @param query          DSL query
     * @return verification results
     * @throws AtlasBaseException
     * @HTTP 200 On successful DSL execution with some results, might return an empty list if execution succeeded
     * without any results
     * @HTTP 400 Invalid DSL or query parameters
     */
    @GET
    @Path("/dsl")
    public VerificationResult verifyDsl(@QueryParam("query") String query) throws AtlasBaseException {

        if (StringUtils.isNotEmpty(query) && query.length() > maxDslQueryLength) {
            throw new AtlasBaseException(AtlasErrorCode.INVALID_QUERY_LENGTH, Constants.MAX_DSL_QUERY_STR_LENGTH);
        }
        VerificationResult verificationResult = new VerificationResult();
        try {

            query = Servlets.decodeQueryString(query);
            QueryParams params       = QueryParams.getNormalizedParams(1,0);
            GremlinQuery gremlinQuery = new AtlasDSL.Translator(query, typeRegistry, params.offset(), params.limit()).translate();
            verificationResult.setValid(true);

        } catch (Exception e){
            verificationResult.setValid(false);
            verificationResult.setErrorMessage(e.getMessage());
        } finally {
        }
        return verificationResult;
    }
}
