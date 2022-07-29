// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {
    // 订单类型
    OrderType,
    // 基础订单类型
    BasicOrderType,
    // 项目类型
    ItemType,
    // 身份说明：是seller还是buyer
    Side
} from "./ConsiderationEnums.sol";

/**
 * @dev An order contains eleven components: an offerer, a zone (or account that
 *      can cancel the order or restrict who can fulfill the order depending on
 *      the type), the order type (specifying partial fill support as well as
 *      restricted order status), the start and end time, a hash that will be
 *      provided to the zone when validating restricted orders, a salt, a key
 *      corresponding to a given conduit, a counter, and an arbitrary number of
 *      offer items that can be spent along with consideration items that must
 *      be received by their respective recipient.
 */
 // 一个订单包含11个组件，购买者，授权者，订单类型
struct OrderComponents {
    // buyer购买者
    address offerer;
    // 授权者
    address zone;
    // 购买NFT所提供的等价资产
    OfferItem[] offer;
    // 售卖的NFT资产项目
    ConsiderationItem[] consideration;
    // 订单类型：交易对+售卖方式，售卖方式有定价出售和拍卖；
    OrderType orderType;
    // 开始时间
    uint256 startTime;
    // 结束时间
    uint256 endTime;
    // 授权者hash
    bytes32 zoneHash;
    // 加盐
    uint256 salt;
    // 
    bytes32 conduitKey;
    // 计数器：？
    uint256 counter;
}

/**
 * @dev An offer item has five components: an item type (ETH or other native
 *      tokens, ERC20, ERC721, and ERC1155, as well as criteria-based ERC721 and
 *      ERC1155), a token address, a dual-purpose "identifierOrCriteria"
 *      component that will either represent a tokenId or a merkle root
 *      depending on the item type, and a start and end amount that support
 *      increasing or decreasing amounts over the duration of the respective
 *      order.
 */
 // 购买包含5个组件
struct OfferItem {
    // token资产类型
    ItemType itemType;
    // 资产的合约地址
    address token;
    // 代表tokenID、或者项目类型的hash
    uint256 identifierOrCriteria;
    // Amount指不同订单金额的变化
    uint256 startAmount;
    uint256 endAmount;
}

/**
 * @dev A consideration item has the same five components as an offer item and
 *      an additional sixth component designating the required recipient of the
 *      item.
 */
// 售卖：有6个组件，5个和购买相对的组件，及1一个指定接收者的组件
struct ConsiderationItem {
    ItemType itemType;
    address token;
    uint256 identifierOrCriteria;
    uint256 startAmount;
    uint256 endAmount;
    // 指定接收者
    address payable recipient;
}

/**
 * @dev A spent item is translated from a utilized offer item and has four
 *      components: an item type (ETH or other native tokens, ERC20, ERC721, and
 *      ERC1155), a token address, a tokenId, and an amount.
 */
// 支付项目：支付四要素
struct SpentItem {
    // 资产类型
    ItemType itemType;
    // 资产的合约地址
    address token;
    // tokenID
    uint256 identifier;
    // 数量
    uint256 amount;
}

/**
 * @dev A received item is translated from a utilized consideration item and has
 *      the same four components as a spent item, as well as an additional fifth
 *      component designating the required recipient of the item.
 */
// 收款项目：收款是四要素
struct ReceivedItem {
    ItemType itemType;
    address token;
    uint256 identifier;
    uint256 amount;
    address payable recipient;
}

/**
 * @dev For basic orders involving ETH / native / ERC20 <=> ERC721 / ERC1155
 *      matching, a group of six functions may be called that only requires a
 *      subset of the usual order arguments. Note the use of a "basicOrderType"
 *      enum; this represents both the usual order type as well as the "route"
 *      of the basic order (a simple derivation function for the basic order
 *      type is `basicOrderType = orderType + (4 * basicOrderRoute)`.)
 */
// 基础订单参数，包括：同质化代币与非同质化代币的匹配；即（ETH/native(其他的平台币/ERC20代币） <=> （ERC721/ERC1155匹配）
// basicOrderType = 订单类型 + 4次资产转发
struct BasicOrderParameters {
    // calldata offset
    // sell售卖资产地址
    address considerationToken; // 0x24
    // 售卖资产的ID
    uint256 considerationIdentifier; // 0x44
    // 售卖资产的数量？
    uint256 considerationAmount; // 0x64
    // 购买者buyer
    address payable offerer; // 0x84
    // 授权者
    address zone; // 0xa4
    // 购买提供的资产合约地址
    address offerToken; // 0xc4
    // 资产ID
    uint256 offerIdentifier; // 0xe4
    // 购买数量
    uint256 offerAmount; // 0x104
    // 基础订单类型
    BasicOrderType basicOrderType; // 0x124
    // 开始时间
    uint256 startTime; // 0x144
    // 结束时间
    uint256 endTime; // 0x164
    // 授权者hash
    bytes32 zoneHash; // 0x184
    uint256 salt; // 0x1a4
    // 
    bytes32 offererConduitKey; // 0x1c4
    //
    bytes32 fulfillerConduitKey; // 0x1e4
    // 指定的接收者
    uint256 totalOriginalAdditionalRecipients; // 0x204
    AdditionalRecipient[] additionalRecipients; // 0x224
    // 
    bytes signature; // 0x244
    // Total length, excluding dynamic array data: 0x264 (580)
}

/**
 * @dev Basic orders can supply any number of additional recipients, with the
 *      implied assumption that they are supplied from the offered ETH (or other
 *      native token) or ERC20 token for the order.
 */
// 基础订单，支持指定接收者
struct AdditionalRecipient {
    uint256 amount;
    address payable recipient;
}

/**
 * @dev The full set of order components, with the exception of the counter,
 *      must be supplied when fulfilling more sophisticated orders or groups of
 *      orders. The total number of original consideration items must also be
 *      supplied, as the caller may specify additional consideration items.
 */
struct OrderParameters {
    address offerer; // 0x00
    address zone; // 0x20
    OfferItem[] offer; // 0x40
    ConsiderationItem[] consideration; // 0x60
    OrderType orderType; // 0x80
    uint256 startTime; // 0xa0
    uint256 endTime; // 0xc0
    bytes32 zoneHash; // 0xe0
    uint256 salt; // 0x100
    bytes32 conduitKey; // 0x120
    uint256 totalOriginalConsiderationItems; // 0x140
    // offer.length                          // 0x160
}

/**
 * @dev Orders require a signature in addition to the other order parameters.
 */
struct Order {
    OrderParameters parameters;
    bytes signature;
}

/**
 * @dev Advanced orders include a numerator (i.e. a fraction to attempt to fill)
 *      and a denominator (the total size of the order) in addition to the
 *      signature and other order parameters. It also supports an optional field
 *      for supplying extra data; this data will be included in a staticcall to
 *      `isValidOrderIncludingExtraData` on the zone for the order if the order
 *      type is restricted and the offerer or zone are not the caller.
 */
struct AdvancedOrder {
    OrderParameters parameters;
    uint120 numerator;
    uint120 denominator;
    bytes signature;
    bytes extraData;
}

/**
 * @dev Orders can be validated (either explicitly via `validate`, or as a
 *      consequence of a full or partial fill), specifically cancelled (they can
 *      also be cancelled in bulk via incrementing a per-zone counter), and
 *      partially or fully filled (with the fraction filled represented by a
 *      numerator and denominator).
 */
 // 订单状态
struct OrderStatus {
    // 有效
    bool isValidated;
    // 已删除
    bool isCancelled;
    // 拆分出售
    uint120 numerator;
    // 整体出售
    uint120 denominator;
}

/**
 * @dev A criteria resolver specifies an order, side (offer vs. consideration),
 *      and item index. It then provides a chosen identifier (i.e. tokenId)
 *      alongside a merkle proof demonstrating the identifier meets the required
 *      criteria.
 */
 // 解析器
struct CriteriaResolver {
    // 订单索引
    uint256 orderIndex;
    // 买卖身份
    Side side;
    uint256 index;
    uint256 identifier;
    bytes32[] criteriaProof;
}

/**
 * @dev A fulfillment is applied to a group of orders. It decrements a series of
 *      offer and consideration items, then generates a single execution
 *      element. A given fulfillment can be applied to as many offer and
 *      consideration items as desired, but must contain at least one offer and
 *      at least one consideration that match. The fulfillment must also remain
 *      consistent on all key parameters across all offer items (same offerer,
 *      token, type, tokenId, and conduit preference) as well as across all
 *      consideration items (token, type, tokenId, and recipient).
 */
struct Fulfillment {
    FulfillmentComponent[] offerComponents;
    FulfillmentComponent[] considerationComponents;
}

/**
 * @dev Each fulfillment component contains one index referencing a specific
 *      order and another referencing a specific offer or consideration item.
 */
struct FulfillmentComponent {
    uint256 orderIndex;
    uint256 itemIndex;
}

/**
 * @dev An execution is triggered once all consideration items have been zeroed
 *      out. It sends the item in question from the offerer to the item's
 *      recipient, optionally sourcing approvals from either this contract
 *      directly or from the offerer's chosen conduit if one is specified. An
 *      execution is not provided as an argument, but rather is derived via
 *      orders, criteria resolvers, and fulfillments (where the total number of
 *      executions will be less than or equal to the total number of indicated
 *      fulfillments) and returned as part of `matchOrders`.
 */
struct Execution {
    ReceivedItem item;
    address offerer;
    bytes32 conduitKey;
}
