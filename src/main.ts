import Koa from 'koa';
import { ApolloServer } from 'apollo-server-koa';

const typeDefs = `
  type Query {
    hello: String!
  }
`

const resolvers = {
  Query: {
    hello: () => {
      return 'Hello world!';
    },
  },
}

// ajout du apollo server pour le front end
const apolloSrv = new ApolloServer({
//@ts-ignore
    typeDefs,
    //@ts-ignore
    resolvers,
    // Make graphql playgroud available at /graphql and include context credentials
    //@ts-ignore
    playground: {
      settings: {
        'request.credentials':'include',
      },
      endpoint: "/graphql",
    },
  }); 

const app = new Koa();

apolloSrv.applyMiddleware({ app, path:"/graphql" });

const httpServer = app.listen({ port: 4000 }, () =>
  console.log(`🚀 Server ready at http://localhost:4000${apolloSrv.graphqlPath}`),
);
apolloSrv.installSubscriptionHandlers(httpServer); 

// Hot Module Replacement 
if (module.hot) { 
    module.hot.accept(); 
    module.hot.dispose(() => {
      httpServer.close();
      console.log('Module disposed. ')
    }
      ); 
    } 
    
